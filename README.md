# Hawktui

Hawktui is a simple and easy to use TUI (Terminal User Interface) library for Ruby. It is built on the [curses](https://github.com/ruby/curses) library.

![hawktui](https://github.com/jonmagic/hawktui/blob/main/hawktui.jpeg)

So far it includes a `StreamingTable` API and more APIs are planned.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "hawktui"
```

Run the following command to install it:

```bash
bundle install
```

## StreamingTable

The `Hawktui::StreamingTable` API can be used to create a full screen table in your terminal that can be updated in real time. This is useful for displaying data that is constantly changing.

```bash
git clone https://github.com/jonmagic/hawktui
cd hawktui
bin/setup
bin/demo
```

https://github.com/user-attachments/assets/9085352f-9f6a-47ae-90c7-cc23946f2d30

See [bin/demo](https://github.com/jonmagic/hawktui/blob/main/bin/demo) for an example of how to use `Hawktui::StreamingTable` and the implementation in [lib/hawktui/streaming_table.rb](https://github.com/jonmagic/hawktui/blob/main/lib/hawktui/streaming_table.rb) for documentation.

## Roadmap

- Add functionality to StreamingTable for selecting and acting on rows.

## Contributors

- [@jonmagic](https://github.com/jonmagic)
