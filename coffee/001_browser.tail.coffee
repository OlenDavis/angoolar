root = window

userAgentTests = [ {
	name: "Android"
	regex: /Android/i
	class: "android"
}, {
	name: "iOS"
	regex: /iPhone|iPad|iPod/i
	class: "ios"
}, {
	name: "iPad"
	regex: /iPad/i
	class: "ipad"
}, {
	name: "iPhone"
	regex: /iPhone|iPod/i
	class: "iphone"
}, {
	name: "Mobile"
	regex: /Android|IEMobile|iPhone|iPad|iPod/i
	class: "mobile"
}, {
	name: "Webkit"
	regex: /Webkit/i
	class: "webkit"
}, {
	name: "Firefox"
	regex: /Firefox/i
	class: "ff"
}, {
	name: "IE"
	regex: /MSIE/i
	class: "ie"
}, {
	name: "IE10"
	regex: /MSIE 10/i
	class: "ie-10"
}, {
	name: "Windows"
	regex: /Windows/i
	class: "windows"
}, {
	name: "Retina"
	class: "retina"
	test: -> window.devicePixelRatio? and window.devicePixelRatio > 1
} ]

# Create browser detection test methods
root.isBrowser = {}
for test in userAgentTests
	if test.regex?
		root.isBrowser[ test.name ] = navigator.userAgent.match test.regex
	else if test.test?
		root.isBrowser[ test.name ] = test.test.call()

root.$window   = angular.element window
root.$document = angular.element document
root.$html     = angular.element document.documentElement

# Add either the class or the not-class to html element
for test in userAgentTests
	root.$html.addClass if root.isBrowser[ test.name ] then test.class else "not-#{ test.class }"
		
	# if root.isBrowser[ test.name ]
	# 	( $ ".not-for-#{ test.class }" ).remove()
	# else
	# 	( $ ".for-#{ test.class }" ).remove()
