# Contributing

For local development, use Docker Compose to automatically compile and serve your work. Results will be available on [localhost:80](http://localhost)

```
docker-compose up -d
```

Deployment occurs automatically when the build for a commit on `master` succeeds

- [Files](#files)
- [Bios](#bios)
- [Repos](#repos)
- [Resumés](#resumés)
- [Works](#works)

## Files

- `_config.yml` Jekyll configuration
- `_bios/` Bios for human beings (just me honestly)
- `_layouts/` Layout templates for pages to use
  - `codehearts.html` The base page template, containing the document head and body w/ footer
  - `pdf.html` The page template for PDF documents
- `_plugins/` Extensions for Jekyll
  - `jekyll-gotenberg.rb` Converts pages with `pdf` set in their front matter to PDF during site generation
- `_repos/` Featured GitHub repos
- `_resumes/` Resumé data
- `_sass/` Sass files to compile and access from the `css/` directory
- `_works/` Featured completed works, with images
- `css/` CSS files to copy to the site output
  - `codehearts.scss` The base site stylesheet
  - `pdf.scss` The PDF stylesheet, containing print-oriented styles
- `icons/` Site icons, such as the favicon and Apple touch icon
  - `safari-pinned-tab.svg` Pinned tab icon for Safari, doubles as the favicons' source image
- `docker-compose.yml` Local development and CI build environment
- `.github` Builds, verifies site integrity, and deploys `master` to production

## Bios

Bios take a brief description and have the following front matter:

- `name` Name or title
- `image` 470px wide image suffixed with `-2x`
  - Create a half-sized image without the `-2x` suffix `convert image-2x.png -scale=50% image.png`
  - Create a webp for both sizes `cwebp image.png -o image.webp && cwebp image-2x.png -o image-2x.webp`
- `image_alt` Accessibility text for `image`
- `links` Array of links with the following properties
  - `name` Name of the link, and label for the button
  - `icon` Name of an icon to replace the text with from the SVG sprite
  - `link` URL for the link

## Repos

Repositories take a super short description and have the following front matter:

- `name` Human readable name, with apostrophes and spaces instead of dashes
- `repo` GitHub repo with the username and repo name, like `codehearts/portfolio`

Repos are displayed in the sorted order of their filenames, so each file is prepended with a number to influence the sorting

## Resumés

Resumés contain only the following front matter:

- `name` Who the resumé is for (basically just me)
- `links` Array of contact links with the following properties
  - `name` Label for the link
  - `link` URL for the link
- `experiences` Array of prior work experience
  - `position` Title of the position held
  - `location` Name of the workplace
  - `start` Start year
  - `end` End year, defaults to "current"
  - `notes` Array of notes about the experience
- `education` Array of schools with the following properties
  - `where` Name of the school
  - `what` Degree obtained
  - `when` Year of graduation
- `technologies` Array of technology experience with the following properties
  - `experienced` Array of technologies you're experienced with
  - `familiar` Array of technologies you're less experienced with
  - `interested` Array of technologies you're interested in learning
- `references` Array of references with the following properties
  - `name` Name of the reference
  - `relation` Position and company, or relationship to the reference
  - `link`: URL to contact the reference
  - `link_label` Label for the reference's contact link

## Works

Works take a brief to moderate description and have the following front matter:

- `name` Name or title
- `time` Full month name and year, or a range if the work had a start/end
- `link` Optional URL for the work
- `link_label` Optional button label for the work's URL, if the URL itself isn't acceptable
- `image` 1024px wide image, 1152px tall to maintain the 8/9 ratio I seem to be using, suffixed with `-2x`
  - Create a half-sized image without the `-2x` suffix `convert image-2x.png -scale=50% image.png`
  - Create a webp for both sizes `cwebp image.png -o image.webp && cwebp image-2x.png -o image-2x.webp`
- `image_alt` Screenshot of my CIF home page design

Works are displayed in the _reverse_ sorted order of their filenames, so each file is prepended with a number to influence the sorting
