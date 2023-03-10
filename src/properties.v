module properties

import os
import strings

// parse_file parses a properties file after reading it and returns a map of the key-value pairs.
pub fn parse_file(path string) !map[string]string {
	return parse(os.read_file(path)!)
}

// parse parses a properties string and returns a map of the key-value pairs.
pub fn parse(raw string) map[string]string {
	mut properties := map[string]string{}

	mut current_raw_index := 0

	mut current_ident := strings.new_builder(30)
	mut current_value := strings.new_builder(30)

	mut parsing_ident := true

	for current_raw_index < raw.len {
		match raw[current_raw_index] {
			`#`, `!` {
				// Ignore until we find a newline.
				for raw[current_raw_index] !in [`\n`, `\r`] {
					current_raw_index++
				}
			}
			` `, `\t` {
				if !parsing_ident {
					current_value.write_rune(raw[current_raw_index])
				}
			}
			`=`, `:` {
				if parsing_ident {
					parsing_ident = false
				}
			}
			`\\` {
				// if raw[current_raw_index + 1] or { `\0` } == `\\`
				// 	|| raw[current_raw_index - 1] == `\\` {
				// 	if parsing_ident {
				// 		current_ident.write_rune(`\\`)
				// 	} else {
				// 		current_value.write_rune(`\\`)
				// 	}
				// }
				// Ignore until we find a newline.
				for raw[current_raw_index] !in [`\n`, `\r`] {
					current_raw_index++
				}
			}
			`\n`, `\r` {
				parsing_ident = true

				if current_ident.len > 0 {
					properties[current_ident.str()] = current_value.str().trim_space()
				}

				current_ident.clear()
				current_value.clear()
			}
			else {
				if !parsing_ident {
					current_value.write_rune(raw[current_raw_index])
				} else {
					current_ident.write_rune(raw[current_raw_index])
				}
			}
		}
		current_raw_index++
	}

	// Handle cases where the file doesn't end with a newline.
	if current_ident.len > 0 {
		properties[current_ident.str()] = current_value.str().trim_space()
	}

	return properties
}
