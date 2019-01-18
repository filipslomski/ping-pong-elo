.PHONY: gui
gui:
	@docker-compose up -d gui
	@docker-compose exec gui elm make src/Main.elm --output app.js --debug

.PHONY: gui_release
gui_release:
	@docker-compose up -d gui
	@docker-compose exec gui elm make src/Main.elm --output app.js --optimize
	@docker-compose exec gui elm-minify app.js

.PHONY: gui_format
gui_format:
	@docker-compose up -d gui
	@docker-compose exec gui elm-format --yes src

.PHONY: gui_analyse
gui_analyse:
	@docker-compose up -d gui
	@docker-compose exec gui elm-analyse
