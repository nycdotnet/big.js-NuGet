big.js-NuGet
============

NuGet package generator for big.js.

Run `npm run generate` from the big.js-NuGet subfolder to build the package.

Relies on node.js and also Bower being installed globally. (npm install -g bower)

Requires PowerShell.

Should automatically fetch the latest version of big.js via bower, update the big.js.nuspec file, and compile the .nupkg file.

If you ever have to manually edit the .nuspec file, run `nuget pack .\big.js.nuspec` to compile it as-is.
