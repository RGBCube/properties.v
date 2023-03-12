module properties

import os
import strings

enum ParseState {
	// We are parsing a key.
	key
	// We are parsing a value.
	value
}

// PropertiesParser is a parser for properties files.
[noinit]
pub struct PropertiesParser {
	// The string we are parsing.
	raw string
mut:
	// The character index we are currently parsing.
	current_index usize
	// The thing we are currently parsing.
	currently_parsing ParseState = .key
	// The current identifier we are parsing.
	current_identifier strings.Builder
	// The current value we are parsing.
	current_value strings.Builder
	// Whether the current line is all whitespace.
	current_line_is_all_whitespace bool = true
	// The number of backslashes we have seen in a row.
	current_backslash_count usize
	// Whether we have encountered an unescaped backslash.
	// This is used for escaping newlines.
	encountered_unescaped_backslash bool
pub mut:
	// The parsed properties.
	properties map[string]string
}

fn (p &PropertiesParser) is_at_end() bool {
	return p.current_index >= p.raw.len - 1
}

fn (p &PropertiesParser) current_rune() rune {
	return p.raw[p.current_index]
}

fn (mut p PropertiesParser) next_rune() rune {
	p.current_index++
	return p.current_rune()
}

fn (p &PropertiesParser) peek_rune() rune {
	return p.raw[p.current_index + 1] or { `\0` }
}

fn (mut p PropertiesParser) write(value rune) {
	match p.currently_parsing {
		.key {
			p.current_identifier.write_rune(value)
		}
		.value {
			p.current_value.write_rune(value)
		}
	}
}

fn (mut p PropertiesParser) save_ident_and_value() {
	if p.current_identifier.len > 0 {
		p.properties[p.current_identifier.str().trim_right(' \t\f')] = p.current_value.str()
	}
}

fn (mut p PropertiesParser) loop_inner() {
	current_rune := p.current_rune()
	print(current_rune)
	defer {
		if !p.is_at_end() {
			p.next_rune()
		}
	}
	match current_rune {
		// Unescaped comment character.
		`#`, `!` {
			if !p.current_line_is_all_whitespace {
				// We are in the middle of a key/value. Write the character.
				p.write(current_rune)
				return
			}

			// We are at the start of a comment. Skip to the end of the line.
			for !p.is_at_end() && p.peek_rune() !in [`\n`, `\r`] {
				p.next_rune()
			}
		}
		// Unescaped whitespace.
		` `, `\t`, `\f` {
			// Ignore whitespace at the start of a line.
			if p.current_line_is_all_whitespace {
				return
			}

			if p.currently_parsing == .value && p.current_value.len > 0 {
				p.current_value.write_rune(current_rune)
				return
			}

			mut index := usize(1)
			mut backslashes_in_a_row := usize(0)
			mut there_is_an_unescaped_separator := false

			for p.current_index + index < p.raw.len {
				peek := p.raw[p.current_index + index]
				match peek {
					`\\` {
						backslashes_in_a_row++
					}
					`\n`, `\r` {
						// Not escaped. New logical line starts.
						if backslashes_in_a_row % 2 == 0 {
							break
						}
						backslashes_in_a_row = 0
					}
					`=`, `:` {
						if backslashes_in_a_row % 2 == 1 {
							continue
						}
						there_is_an_unescaped_separator = true
					}
					else {
						backslashes_in_a_row = 0
					}
				}
				index++
			}

			if there_is_an_unescaped_separator {
				// We are parsing a key and there is an unescaped separator in the rest of the line.
				// Write the whitespace.
				p.write(current_rune)
			}
		}
		// Unescaped separator.
		`=`, `:` {
			if p.currently_parsing == .value {
				p.write(current_rune)
			}
			p.currently_parsing = .value
			p.current_line_is_all_whitespace = false
			p.current_backslash_count = 0
		}
		// Newline. May or may not be escaped.
		`\n`, `\r` {
			// We are at the end of a line. Not escaped.
			if p.current_backslash_count % 2 == 0 || p.encountered_unescaped_backslash {
				p.save_ident_and_value()
				p.currently_parsing = .key
				p.encountered_unescaped_backslash = false
			}
			p.current_line_is_all_whitespace = true
			p.current_backslash_count = 0
		}
		`\\` {
			p.current_line_is_all_whitespace = false
			peek := p.peek_rune()

			// Escaped whitespace/comment character/seperator.
			// \\\! -> ! is escaped as there is an odd number of backslashes.
			if p.current_backslash_count % 2 == 1 {
				if peek in [` `, `\t`, `\f`, `#`, `!`, `=`, `:`] {
					p.current_backslash_count = 0
					p.write(p.next_rune())
				}
				return
			}

			// \\\x -> The last \ is not escaped as there is
			// an even number of backslashes before it.
			if peek != `\\` {
				p.encountered_unescaped_backslash = true
				return
			}

			// Escaped backslash.
			// Just reset the backslash count as the number doesn't matter.
			// It only needs to be even here.
			p.current_backslash_count = 0
			p.write(p.next_rune())
		}
		else {
			p.current_line_is_all_whitespace = false
			p.write(current_rune)
		}
	}
}

// parse parses the properties file.
// The parsed properties are stored in the properties field.
pub fn (mut p PropertiesParser) parse() {
	for !p.is_at_end() {
		p.loop_inner()
	}
	p.loop_inner()
	// Handle files not ending in a newline.
	p.save_ident_and_value()
}

// parse_file parses a properties file after reading it and returns a map of the key-value pairs.
pub fn parse_file(path string) !map[string]string {
	return parse(os.read_file(path)!)
}

// parse parses a properties string and returns a map of the key-value pairs.
pub fn parse(raw string) map[string]string {
	mut parser := PropertiesParser{
		raw: raw
	}

	parser.parse()
	return parser.properties
}
