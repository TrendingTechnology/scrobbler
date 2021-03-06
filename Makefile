.PHONY: all secrets test showCoverage analysis run ios ipa android icons screenshots clean

CODE = $(wildcard lib/**) $(wildcard test/**)
ASSETS = $(wildcard assets/**)
SOURCES = $(CODE) $(ASSETS)

all: analysis showCoverage

secrets:
	[ -f .env ] && source .env; flutter pub run tool/generate_secrets_file.dart

test: coverage/lcov.info

coverage/lcov.info: $(SOURCES)
	flutter test --coverage

coverage/html/index.html: coverage/lcov.info
	genhtml -q coverage/lcov.info -o coverage/html

showCoverage: coverage/html/index.html
	open coverage/html/index.html

analysis: analysis.txt

analysis.txt: $(CODE) analysis_options.yaml
	flutter analyze --write analysis.txt

run: test
	flutter run --release $(if $(DEVICE),-d "$(DEVICE)")

icons:
	flutter pub run flutter_launcher_icons:main

ios: test
	flutter build ios --release

ipa: test
	flutter build ios --release \
    && mkdir -p build/ios/iphoneos/Payload \
    && cd build/ios/iphoneos \
    && rm -rf Payload/Runner.app app.ipa \
    && mv Runner.app Payload/ \
    && zip -r app.ipa Payload

android: test
	flutter build appbundle --release

screenshots:
	screenshots \
	&& cd ios/fastlane/screenshots/en-US \
	&& fastlane frameit

clean:
	flutter clean