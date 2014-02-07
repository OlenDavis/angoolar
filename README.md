ANGööLAR
========
Putting the "oOOoo" in AngoOOoolar. Taking "u" to a land of object-oriented ease.

# File Naming & Build Order

The build process is currently driven by placing all related files into a directory together and then concatenating and minifying them together with simple alphabetical ordering. The following are recognized as "related files":
*	Two types of Coffee files, and two types of JS files:
	*	*.tail.coffee

		These are all rendered into *.tail.js files.

	*	*.head.coffee

		These are all rendered into *.head.js files.

	*	*.tail.js

		Once the Coffee files have all been rendered into their corresponding *.tail.js files, they are all concatenated and uglified together into a single tail.js file.

		Then, they will all be added as `<script>` tags at the end of the page just before `</body>` (hence, the '.tail') either individually or just the one concatenated, uglified tail.js depending on the build environment given in package.json.
	*	*.head.js

		These are treated just the same as *.tail.js files, except that they are added to `<head>` rather than to the end of `<body>` either individually or as one concatenated, uglified file.

* There are also two types of SCSS/CSS files:
	*	*.head.scss

		These are all rendered into *.head.css files.

	*	*.body.scss

		These are all rendered into *.body.css files.

	*	*.head.css

		These go into `<head>` either individually or concatenated/minified depending on the build environment given in package.json.

	*	*.body.css

		These go into `<body>` not just before the `</body>` tag like *.tail.js files, but just after the opening `<body>` tag at the top of the body, hence being '.body' not '.tail'.


Files names determine their functional order. This matters very much for Coffee/JS files and SCSS/CSS files, but in different ways:
*	For Coffee/JS

	It determines what is and is not yet on the root. If you get a "Property $_name doesn't exist on the prototype of ..." you've probably named a file in such a way as to run before a dependency has been declared.

*	For SCSS/CSS

	It determines what styles override what other styles. The Zootstrap is written in such a way that styles like .red.secondary.coloring and .blue.secondary.coloring are perfectly equal in terms of CSS style-precedence, so the only thing that determines whether that element will be red or blue is whether red or blue comes last, and that's determined not only by the order of those themes' declaration in an SCSS/CSS file, but also the naming of the two files that declare the different themes (and it's likely they'll be in separate files as this can easily cut 7 minutes off the SASS build step when rendering 10 themes).


## The Convention

> First, a note about extending components:
> *	Closely related? Add 1 to the prefix
> *	Not so closely related? Bump the prefix to the next tens digit above the dependencies with the highest prefix.

Not all components are "high-level" components. For instance, a class that extends a zAngular class that starts with Base like BaseController or BaseDirective or even BaseResourceRequester or BaseHttpInterceptor - as high-level as that might seem, it just makes it a basic controller or directive or requester or interceptor. A high-level component is a component that either extends another component (that extends one of those BaseWhatevers), or declares one or more of those other components as dependencies (e.g. a class property of $_dependencies: [ root.SomeAwesomeInterceptor ] would make your class a high-level component whose filename needs to be prefixed appropriately).

Generally the only time to need to do anything other than looking at this list of prefixes and asking yourself, "I've got a factory here, what should I use?", finding 5**_*.tail.js and naming your file 500_your_factory.tail.coffee and moving on to bigger and better things is when your YourFactory either extends another factory (not just BaseFactory), or actually depends on another zAngular factory (via the $_dependencies property).

In that case, what you'll do is actually simple thanks to the different classes of components (i.e. the fact that Factories can't/shouldn't depend on Directives, or that plain classes shouldn't depend on any zAngular components) as well as the separation given by cages and the different component types in the cage/coffee/ directory. You'll want to look at the filenames of the components it depends on, and the one with the highest prefix is in another cage or another component type directory just start your name at the next tens digit of the highest prefix among the dependencies.  E.g. If you have a factory that depends on a factory named 510_a_basic_factory.tail.coffee, then name yours 520_basically_an_extended_factory.tail.coffee. If on the other hand, your highest dependency in question is in your cage and also a factory (and therefore really closely related to your new component), just go ahead an add one to its prefix, which would've made BasicallyAnExtendedFactory's filename 511_basically_an_extended_factory.tail.coffee.

And now, here are the 11 current sets of Coffee/JS source files:

### 0**_*.tail.js Libraries and Global Utilities
Javascript Libraries and other globally used utility scripts
e.g. AngularJS, Underscore, Modernizr, jQuery, and the 001_application.tail.js script

### 08*_*.tail.js - 09*_*.tail.js Angoolar Base Classes
All low level Angular helper/base classes
e.g. BaseController and BaseDirective

### 1**_*.tail.js Plain Classes & Custom Base Classes
All raw javascript functions/classes used elsewhere in page scripts. Note that since these come after all Angoolar base classes, you can create your own Angoolar base classes here, and have your factories/modules/etc extend these rather than the built-in Angoolar base classes.
e.g. Flags class and its subclass RequestStatus.

### 2**_*.tail.js Angoolar Modules
All Angular modules/apps
e.g. the default App

### 3**_*.tail.js Angoolar Low-level Factories
All low-level factories, like options-providers or utility factories.
e.g. SectionTypes, PersistentState, or Base64

### 4**_*.tail.js Angoolar Filters
All custom filter factories
e.g. Sum

### 5**_*.tail.js Angoolar Requesters
All custom requester factories extending BaseRequester
e.g. Sum

### 6**_*.tail.js Angoolar High-level Factories
All high-level factories whether they be for managing application state or $http interceptors.
e.g. ProgrammerState, CommunicationInterceptor

### 7**_*.tail.js Angoolar Controllers
All custom controllers
e.g. ChannelId (controller)

### 8**_*.tail.js Angoolar Directives
All custom directives
e.g. ChannelId (directive)

### 9**_*.tail.js Angoolar Module Blocks
All Angular config and run blocks for modules
e.g. GuruConfig

### 999*_*.tail.js Angoolar Final Page Setup Scripts
Any scripts that need to run after really everything to do with zAngular has been declared.
e.g. 9990_application.tail.coffee

In addition to these, there are several special files with basically established naming:
*	000_angular.tail.js - Angular's source is expected to come before anything (that might depend on it)
*	001_application.tail.coffee - this creates all the Angoolar project scaffolding functions such as root.addDirective.
*	9990_application.tail.coffee - this is the capstone to all the Angoolar project scaffolding that actually makes use of the components aggregated by those project scaffolding functions.
*	9991_templates.tail.js - this is constructed by the Grunt build process, and is all the templates (whether in `.../template/directive` or `.../template/view`) with whitespace and comments eliminated and precached into a JS file so no templates should require an HTTP request when used.