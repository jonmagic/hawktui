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

## Development

Run the tests with:

```bash
rake
```

Run the standard linter and fix issues with:

```bash
rake standard:fix
```

I use LLMs a lot so I've added a couple of scripts that make it easier to write prompts.
- [bin/code_for_prompt](https://github.com/jonmagic/hawktui/blob/main/bin/code_for_prompt) - This script will output everything in lib and test that you might need when providing a prompt with context. I usually pipe this to `pbcopy` and then paste it into the prompt.
    ```bash
    bin/code_for_prompt | pbcopy
    ```
- [bin/token_count](https://github.com/jonmagic/hawktui/blob/main/bin/token_count) - This script will output the number of tokens either piped to it or by running whatever is passed to it as a command. It defaults to counting for ChatGPT 4o but you can set the model to claude instead. Run the command without arguments to see the usage.
    ```bash
    bin/code_for_prompt | bin/token_count
    ```

## Contributors

- [@jonmagic](https://github.com/jonmagic)
