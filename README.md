# Srcset Image Tags for Middleman

## Usage

Add the gem to your site's Gemfile.

~~~~
gem 'middleman-srcset_images'
~~~~

Create a configuration file as outlined below.

In your Markdown files, use this syntax for images:

~~~
![Alt text](/path/to/image.jpg!half)
~~~

where _half_ is one of the configured image sizes (see below). The result will
be an image tag with _srcset_ and _sizes_ attributes. To create a linked image,
add another exclamation mark followed by the destination URL:

~~~
![Linked Image](/path/to/image.jpg!half!/path/or/url)
~~~


Relative image paths are assumed to be local to the article, and the file
extension is assumed to be `jpg` if not present. So when using the 'one
directory per page' approach where you have a file layout like this:

~~~
source/
  some-article.html.md
  some-article/
    image.jpg
    another_image.jpg
~~~

you can significantly shorten your markup like this:

~~~
![Lorem Ipsum](image!full)
~~~



## Configuration

Configuration takes place in `data/srcset_images.yml`.

### Sizes

The keys in this hash are the sizes that can be used in Markdown / with the
`image_tag` helper. The value is put into the _sizes_ attribute of the
resulting `img` tag. The purpose of this attribute is to give the browser a hint
about how big this image will actually be rendered (relative to the screen
size) due to your CSS rules.

The sample below is for a site which can display content images in 3
different sizes, and that has a separate config for teaser images. On small
devices, all images are rendered at full width, while on larger devices, they
only take a fraction of the actual screen width. The separate _teaser_ config
is only there to allow for different cropping rules in the image versions
config.

### Image Versions

Configure scaling options for landscape and portrait images. These rules
determine which sizes of images will be created when building your site, and
also what goes into the `srcset` attribute of the `img` tag.

Besides the _landscape_ and _portrait_ keys, which act as fallbacks for images
of landscape or portrait dimensions, you can add any other keys here for
different use cases (i.e. cropping to a fixed xy ratio for teaser images as is
done in the sample below).

When rendering an `img` tag, the image version config to be used is picked as
follows:

- if there is a key matching the _size_ parameter, use this config. This would
  be the case for _teaser_ images in the sample below.
- otherwise, check the layout of the image and pick the _portrait_ config if
  the image is higher than wide, and the _landscape_ otherwise.


### Sample data/srcset\_images.yml

~~~~

---

sizes:
  full: "(min-width: 768px) 90vw, 100vw"
  half: "(min-width: 768px) 45vw, 100vw"
  third: "(min-width: 768px) 30vw, 100vw"
  teaser: "(min-width: 768px) 30vw, 100vw"

image_versions:
  # configuration for landscape and square images
  landscape:
    # path pattern this config should be applied to
    images: posts/**/*.jpg
    quality: 80
    srcset:
      -
        width: 2000
      -
        width: 1400
        is_default: true
      -
        width: 800
      -
        width: 400

  # portrait content images, cropped to 3:4
  portrait:
    images: posts/**/*.jpg
    quality: 80
    crop: true
    srcset:
      -
        height: 1800
        width: 1350
      -
        height: 1200
        width: 900
        is_default: true
      -
        height: 800
        width: 600

  # teaser image, cropped to landscape 3:2
  teaser:
    images: posts/**/*.jpg
    crop: true
    quality: 80
    srcset:
      -
        width: 1800
        height: 1200
      -
        width: 1200
        height: 800
        is_default: true
      -
        width: 600
        height: 400

~~~~

