# codehearts

My personal portfolio site, served statically and cooked up with Jekyll

## Development

### Files

- `_config.yml` Jekyll configuration
- `_bios/` Bios for human beings (just me honestly)
- `_layouts/` Layout templates for pages to use
  - `codehearts.html` The base page template, containing the document head and body w/ footer
- `css/` CSS files to copy to the site output
  - `codehearts.scss` The base site stylesheet
- `img/` Image files copied as-is to the site output, no resizing or optimization occurs

### Bios

Bios take a brief description and have the following front matter:

- `name` Name or title
- `image` 470px wide image
- `image_alt` Accessibility text for `image`
- `links` Array of links with the following properties
  - `name` Name of the link, and label for the button
  - `link` URL for the link
