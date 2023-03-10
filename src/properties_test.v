module properties

fn test_properties_parse() ! {
	props := parse_file('./samples/test.properties')!

	println(props)
}
