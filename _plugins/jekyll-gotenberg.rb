require 'net/http'

# Convert an HTML file to PDF
# The original HTML file is then removed
#
# This function makes a request to a Gotenberg server to render the site by URL
def convert_html_to_pdf(item)
  # Read the global Jekyll config
  pdf_config = item.site.config.fetch 'pdf', {}
  gotenberg_config = pdf_config.fetch 'gotenberg', {}
  web_config = pdf_config.fetch 'web', {}

  # Establish hosts and ports for generation
  gotenberg_host = gotenberg_config.fetch 'host', 'localhost'
  gotenberg_port = gotenberg_config.fetch 'port', 3000
  web_host = web_config.fetch  'host', 'localhost'
  web_port = web_config.fetch 'port', 4000

  # Establish the Gotenberg endpoint
  endpoint = URI("http://#{gotenberg_host}:#{gotenberg_port}/forms/chromium/convert/url")

  # Create a request to the Gotenberg endpoint
  request = Net::HTTP::Post.new(endpoint)
  request.set_form({
    'url' => "http://#{web_host}:#{web_port}#{item.url}",
    'marginTop' => '0',
    'marginBottom' => '0',
    'marginLeft' => '0',
    'marginRight' => '0',
    'waitDelay' => '1s'
  }, 'multipart/form-data')

  # Connect to the Gotenberg endpoint
  http = Net::HTTP.start(
    endpoint.host, endpoint.port, max_retries: 10) rescue retry

  # Communicate with the Gotenberg endpoint
  response = http.request(request)
  http.finish

  # Ensure the response was 200
  response.value rescue raise 'Failed to connect with Gotenberg endpoint'

  # Write the PDF to the destination
  pdf_filename = File.join item.site.dest, item.relative_path[0..-6] + '.pdf'
  File.open(pdf_filename, 'wb') { |file| file.write(response.body) }

  # Remove the HTML file and its parent directory if empty
  File.delete item.destination('')
  Dir.delete File.dirname(item.destination('')) rescue nil
end

# Convert HTML to PDF after site is written if the front matter sets `pdf` true
Jekyll::Hooks.register :site, :post_write, priority: Jekyll::Hooks::PRIORITY_MAP[:low] do |site|
  # Search through pages and documents
  (site.pages + site.documents).each do |item|
    convert_html_to_pdf(item) if item.data['pdf']
  end
end
