casper.start( "http://localhost/projects" ).then ->
	phantomcss.screenshot 'body', 'Projects'