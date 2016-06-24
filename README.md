# paperclip-cloudinary

[![Gem
Version](https://badge.fury.io/rb/paperclip-cloudinary.svg)](https://badge.fury.io/rb/paperclip-cloudinary)

`paperclip-cloudinary` allows Rails models managed via [Paperclip](http://github.com/thoughtbot/paperclip) to store image and file assets on a Cloudinary instance.

[Cloudinary](http://cloudinary.com) is an image, file and video hosting service that allows for
dynamic, on-the-fly transformations of images with fast results. There
is a free tier to allow you to get started immediately, with paid tiers
available once you start gaining traction.

This library just provides the basics -- provided with your Cloudinary
credentials, use paperclip-cloudinary to manage your attachments.

At this stage, not all of the API has been exposed for Cloudinary, so if
it seems you can't quite leverage all of Cloudinary's functionality yet,
that's why. But much Cloudinary's best offerings, like dynamic image transformation, 
are readily available.

Note: Cloudinary also supports CarrierWave and Attachinary, and will probably be more
consistently maintained going forward. But if you are distinctively
looking for a Paperclip-based solution, this gem is for you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paperclip-cloudinary'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paperclip-cloudinary

## Usage

Download your configuration YAML file and place it in your `config`
directory.  You can grab it here:

[https://cloudinary.com/console/cloudinary.yml](https://cloudinary.com/console/cloudinary.yml)

This will enable the
[Cloudinary gem](https://github.com/cloudinary/cloudinary_gem) to pick
up your configuration automatically.

To use in your model, add the following options for `storage` to `has_attached_file`

```ruby
has_attached_file :image,
  :storage => :cloudinary
```

If you have put your cloudinary config file at a location other than
config/cloudinary.yml (which is ill-advised), you can specify where the
credentials are located by specifying the `cloudinary_credentials`
option:

```ruby
has_attached_file :image,
  :storage => :cloudinary,
  :cloudinary_credentials => Rails.root.join("config/cloudinary.yml")
```

The `cloudinary_credentials` can be a file location, a file, or a Hash
of options.

### Upload Options

Cloudinary supports a host of [upload
options](http://cloudinary.com/documentation/image_upload_api_reference#upload)
that can be run at the time an image or file is uploaded.

This gem specifies a few of these options for you:

* `public_id`: Defines the name of this file
* `use_filename`: set to true to use the filename
* `unique_filename`: set to false
* `overwrite`: set to true to overwrite existing files with each re-upload
* `invalidate`: set to true to invalidate CDN cache with each re-upload

You can specify additional options by supplying a Hash to `:cloudinary_upload_options` 
in your `has_attached_file` declaration.  The following options are supported here:

* `default`: Default options applied to all styles of this upload
* `styles`: A Hash of style names to the upload options for that
  particular style.

See Cloudinary documentation for list of keys and expected value options and data types. 
The value can also be a `lambda` function that returns the appropriate value.  The 
`style_name` and Paperclip `attachment` object will be passed to your function.

```ruby
has_attached_file :image,
    :storage => :cloudinary,
    :styles => { :avatar => '200x200>' },
    :cloudinary_upload_options => {
        :default => {
            :tags => [ 'Web' ],
            :context => {
                :caption => lambda { |style_name, attachment| attachment.instance.caption }
            }
        },
        :styles => {
            :avatar => {
                :tags => [ 'Web', 'Avatar' ],
                :transformation => [
                    { :crop => 'thumb', :gravity => 'face' }
                ]
            }
        }
    }
```

Here, all image versions would be uploaded with a caption taken from the model's caption parameter and 
a tag "Web."  For the avatar style, the tags would be overridden to be both "Web" and "Avatar," and 
an [incoming transformation](http://cloudinary.com/documentation/rails_image_upload#incoming_transformations) would 
be run to crop the photo to a thumbnail and gravitate the center toward the user's face using Cloudinary's 
facial recognition features.

The gem-provided default options can not be overridden.

### URL Options

One of Cloudinary's biggest draws is the ability to manipulate images
on the fly via URL parameters. You can specify the URL options in your
attachment configuration as well as in-line.  See the Cloudinary
documentation for a list of all supported parameters.

#### Attachment Configuration

```ruby
has_attached_file :image
    :storage => :cloudinary,
    :styles => { :avatar => '200x200>' },
    :cloudinary_url_options => {
        :default => {
            :secure => true
        },
        :styles => {
            :avatar => {
                :resource_type => 'raw'
            }
        }
    }
```

Like upload options, the default options (optional) will be used first
for all calls, then the style-specific ones, if applicable.

#### In-line Configuration

```ruby
model.image.url(:avatar, :cloudinary => { :secure => true,
:resource_type => 'raw' }
```

These can be use in addition to the URL options provided in the
attachment configuration, or they can be used standalone. Options
provided in-line will override any options specified in the attachment
configuration.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GoGoCarl/paperclip-cloudinary.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

