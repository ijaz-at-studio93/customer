# A file contains the most used commnads
# Q: How to run?
# In your terminal enter this command `make get` it will execute the `dart pub get`
# Q: What are requirements for using this file or executing the make commands?
# For Mac not need to install anything 
# Linus:
# sudo apt install make
# Windows:	
#  Run powershell as an adminstrator
# Execute the commands below:
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# choco install make
# Reboot your system and exceute the command `make get`

get:
	 flutter pub get

clean:
	flutter clean && make get

generate: 
	dart run build_runner build --delete-conflicting-outputs

watch: 
	dart run build_runner watch --delete-conflicting-outputs

getAndGenerate:
	make get && make generate

pod-install:
	cd ios/ && pod install

pod-repo-update:
	cd ios/ && pod install --repo-update

reset-pod:
	cd ios/ && rm -rf Podfile.lock && pod install	

pod-deintegrate-and-install:
	cd ios/ && pod deintegrate && pod install

apk:
	flutter build apk --release

devApk:
	flutter build apk --release --dart-define=ENVIRONMENT=development

test-apk:
	flutter build apk --release --dart-define=STNDRD_ENV=true

fix:
	dart fix --apply && dart format . && dart sort_imports_script.dart lib/
	
gen:
	fluttergen

git-config:
	git config user.name && git config user.email	

set-git-config:
	git config --global user.name "ijaz-at-studio93" && git config --global user.email "muhammad.ijaz@studio93.io"