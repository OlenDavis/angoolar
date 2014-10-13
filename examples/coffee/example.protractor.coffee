describe 'Angoolar', ->
	it "should load Angular", ->
		protractor.getInstance().ignoreSynchronization = yes;
		browser.get '/' 
		browser.waitForAngular().then(
			-> yes
			-> no
		).then ( angularLoaded ) ->
			expect( angularLoaded ).toBeTruthy()