import PackageDescription

let package = Package(
    name: "Smud",
    dependencies: [
        .Package(url: "https://github.com/smud/ConfigFile.git", majorVersion: 1),
        .Package(url: "https://github.com/smud/Utils.git", majorVersion: 1),
    ]
)

