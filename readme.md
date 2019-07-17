# codehearts

My personal portfolio site, served statically and cooked up with Jekyll

## Development

For local development, run Jekyll through Docker to automatically compile and serve your work. Results will be available at [0.0.0.0:4000](http://0.0.0.0:4000)

```
docker run --rm -v$PWD:/srv/jekyll -p4000:4000 jekyll/jekyll jekyll serve
```

Deployment occurs automatically when the build for a commit on `master` succeeds

### Files

- `_config.yml` Jekyll configuration
- `_bios/` Bios for human beings (just me honestly)
- `_layouts/` Layout templates for pages to use
  - `codehearts.html` The base page template, containing the document head and body w/ footer
- `_repos/` Featured GitHub repos
- `_sass/` Sass files to compile and access from the `css/` directory
- `_works/` Featured completed works, with images
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

### Repos

Repositories take a super short description and have the following front matter:

- `name` Human readable name, with apostrophes and spaces instead of dashes
- `repo` GitHub repo with the username and repo name, like `codehearts/codehearts`

Repos are displayed in the sorted order of their filenames, so each file is prepended with a number to influence the sorting

### Works

Works take a brief to moderate description and have the following front matter:

- `name` Name or title
- `time` Full month name and year, or a range if the work had a start/end
- `link` Optional URL for the work
- `link_label` Optional button label for the work's URL, if the URL itself isn't acceptable
- `image` 1024px wide image, 1152px tall to maintain the 8/9 ratio I seem to be using
- `image_alt` Screenshot of my CIF home page design

Works are displayed in the _reverse_ sorted order of their filenames, so each file is prepended with a number to influence the sorting
