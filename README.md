Hyde Page JS
=============

A Jekyll 4 plugin that enables concatenating, processing and caching js files for pages.


Installation
------------

1. Add Hyde Page JS to your Gemfile

`gem 'hyde-page-js', '~> 0.4.0'`

2. Add entry to your Jekyll config under plugins

```yaml
plugins:
  - hyde-page-js
  ...
```

3. Add the liquid tag to your layout

```liquid
{%- for file in site.data.js_files -%}
<script src="{{ file.path | prepend: '/' | prepend: site.baseurl }}"></script>
{%- endfor %}
```

which will render as the following, based on the number of separate js files.

```html
<script src="/assets/js/7ccd0b378a0983457a529eb1bbb165a5.js"></script>
```
```liquid
{%- for file in site.data.js_files -%}
<script>
  {{ file.content }}
</script>
{%- endfor %}
```

```html
<script>
  console.log('hello world');
</script>
```


4. Add `js:` to your frontmatter.

`js:` is a list of files defined in the `asset_path` in configuration.

```html
---
layout: home.html
js:
	- home.js
	- promotion.js
---
<h1>Hyde Page JS</h1>
```

The generated js file will contain the contents of `home.js` and `promotion.js` then cached.

If any other page uses `home.js` and `promotion.js` they will reuse the same generated js file.

Configuration
-------------

Hyde Page JS comes with the following configuration. Override as necessary in your Jekyll Config

```yaml
hyde_page_js:
  source: assets/js
  destination: assets/js
  minify: true
  enable: true
  keep_files: true
	dev_mode: false
```

`source`
: relative path from the root of your Jekyll directory to the source js file directory

`destination`
: relative path from the root of your generated site to the location of the generated js files

`minify`
: minify the js generated using [Terser](https://github.com/ahorek/terser-ruby)

`enable`
: will generate the js files when enabled, otherwise will skip the process at build time

`keep_files`
: will not delete files between builds, and will reuse existing files if they match.

`dev_mode`
: skip minification of js, the filename will be formed of the files included with a trailing hash to bust cache. eg: `base.js, home.js => base-home-2d738a.js`.

