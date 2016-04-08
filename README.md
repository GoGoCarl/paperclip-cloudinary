# Paperclip::Cloudinary

Paperclip-cloudinary allows simple storage of image assets to a
Cloudinary instance.

Cloudinary is an image, file and video hosting service that allows for
dynamic, on-the-fly transformations of images with fast results. There
is a free tier to allow you to get started immediately, with paid tiers
available once you start gaining traction.

This library just provides the basics -- provided with your Cloudinary
credentials, use paperclip-cloudinary to manage your attachments.

At this stage, not all of the API has been exposed for Cloudinary, so if
it seems you can't quite leverage all of Cloudinary's functionality yet,
that's why.

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
[https://github.com/cloudinary/cloudinary_gem](Cloudinary gem) to pick
up your configuration automatically.

To use in your model, add the following options for `storage` and
`cloudinary_credentials` to `has_attached_file`

```ruby
has_attached_file :image,
  :storage => :cloudinary,
  :cloudinary_credentials => Rails.root.join("config/cloudinary.yml")
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GoGoCarl/paperclip-cloudinary.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

