import PackageDescription

let package = Package(
    name: "Smud",
    dependencies: [
        .Package(url: "https://github.com/smud/CEvent.git", majorVersion: 0),
        .Package(url: "https://github.com/smud/ConfigFile.git", majorVersion: 0),
        .Package(url: "https://github.com/smud/Utils.git", majorVersion: 0),
    ]
)

