require 'net/http'
require 'json'
require 'uri'

def scrape_all_tags
  begin
    api_url = 'https://danbooru.donmai.us/tags.json'
    tags_per_page = 1000
    page = 1
    all_tags = []

    loop do
      # Construct the URL with query parameters
      uri = URI("#{api_url}?limit=#{tags_per_page}&page=#{page}&order=post_count&search=")
      
      # Send HTTP request
      response = Net::HTTP.get_response(uri)
      break unless response.is_a?(Net::HTTPSuccess)

      # Parse JSON response
      data = JSON.parse(response.body)
      
      # Break if no more tags or reached page 1000
      break if data.empty? || page == 1000

      # Extract tag names
      tags = data.map { |tag| tag['name'] }
      all_tags.concat(tags)

      puts "Page: #{page}"
      puts "URL: #{uri}"

      page += 1
    end

    # Write tags to JSON file
    File.open('all_tags.json', 'w') do |file|
      # Convert to JSON with pretty formatting
      file.write(JSON.pretty_generate(all_tags))
    end

    puts 'All tags scraped and written to all_tags.json'
    puts "Total tags scraped: #{all_tags.size}"
  rescue StandardError => e
    puts "Error scraping tags: #{e.message}"
    puts e.backtrace
  end
end

# Run the scraper
scrape_all_tags