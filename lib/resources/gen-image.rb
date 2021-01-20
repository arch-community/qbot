require 'rmagick'

def mk_text_draw(font, size, color)
  draw = Magick::Draw.new

  draw.pointsize = size
  draw.font = font
  draw.fill = color
  draw.gravity = Magick::NorthWestGravity

  draw
end

def fill(img, color)
  Magick::Draw
    .new { self.fill = color }
    .tap { _1.color(0, 0, Magick::ResetMethod) }
    .draw(img)
end

username = 'Foxboron'
user_color = '#FFFFFF'

time = 'Today at 4:13 PM'
time_color = '#72767D'

text = "I can't believe it's not Discord!\ntest\ntest"
text_color = '#DCDDDE'

bg = '#36393F'

out = Magick::Image.new(400, 300)
out.background_color = '#00000000'

# Draw background
fill(out, bg)

username_image = \
  Magick::Image
  .new(400, 300)
  .tap { fill _1, 'transparent' }
  .tap { |im| mk_text_draw('./Whitney-Medium-Pro.otf', 16, user_color).annotate(im, 0, 0, 0, 1, username) }
  .trim
  .border(10, 10, 'transparent')
  .write('username.png')

mk_text_draw('./Whitney-Book-Pro.otf', 12, time_color)
  .annotate(out, 0, 0, 0, 25, time)

mk_text_draw('./Whitney-Book-Pro.otf', 16, text_color)
  .tap { _1.interline_spacing = 4 }
  .annotate(out, 0, 0, 0, 50, text)

out
  .trim
  .border(10, 10, bg)
  .write('./text.png')
