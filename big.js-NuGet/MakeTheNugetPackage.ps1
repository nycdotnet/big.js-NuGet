#
# Makes the NuGet package for big.js
#
# Requires Bower to be installed globally (npm install -g bower) see http://bower.io/ for more info.
# Run via npm:
#
# npm run generate
#

function warn-no-bower() {
	write-warning "Bower is not installed."
	write-warning "You should install it globally by issuing the command:"
	write-warning "npm install -g bower"
	Exit
}

function warn-no-nuget() {
	write-warning "NuGet was not detected on the path."
	write-warning "Please follow the instructions here to get it and set it up on the path:"
	write-warning "http://docs.nuget.org/docs/creating-packages/creating-and-publishing-a-package"
	Exit
}

function check-bower() {
  try
  {
	  $result = bower | out-string
	  if ($result -eq $null -or $result -eq "") {
		warn-no-bower
	  }
	  "Bower detected."
  }
  catch
  {
	$_.message
	warn-no-bower
  }
}

function check-nuget() {
  try
  {
	  $result = nuget
	  if ($result -eq $null) {
		warn-no-nuget
	  }
	  "NuGet detected on path."
  }
  catch
  {
	$_.message
	warn-no-nuget
  }
}

function fetch-latest-with-bower() {
	"Fetching latest version with Bower"
	bower install
}

function get-package-info() {
	Get-Content "bower_components\big.js\package.json" | Out-String | ConvertFrom-Json
}

function create-scripts-folder-and-copy-scripts-there() {
    if ([IO.Directory]::Exists(".\Content") -eq $false) {
		"Creating 'Content' folder"
		mkdir .\Content | Out-Null
	}
	if ([IO.Directory]::Exists(".\Content\Scripts") -eq $false) {
		"Creating 'Scripts' folder"
		mkdir .\Content\Scripts | Out-Null
	}
	"Setting up Scripts folder"
	del .\Scripts\*.* | Out-Null
	[IO.File]::Copy("bower_components\big.js\big.js", "Content\Scripts\big.js", $true);
	[IO.File]::Copy("bower_components\big.js\big.min.js", "Content\Scripts\big.min.js", $true);
	[IO.File]::Copy("bower_components\big.js\LICENCE", "Content\Scripts\big.js.LICENCE", $true);
}

function compile-nuget-package() {
	NuGet Pack big.js.nuspec
}

function report-library-version($packageInfo) {
	$version = $packageInfo.version;
	"Found library version $version";
}

function extract-tags($keywordsElement) {
	$tags = ""
	$keywordsElement | % {
		$tags += $_ + " "
	}
	$tags.TrimEnd()
}

function update-nuspec($packageInfo) {
	"updating the .nuspec file"
	#Load up the nuspec doc (XML)
	$xml = New-Object XML
	$xml.PreserveWhitespace = $true
    $xml.Load("big.js.nuspec")
	$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
	$ns.AddNamespace("nuspec", "http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd")
	$root = $xml.DocumentElement;
	$tags = extract-tags($packageInfo.keywords)
	$tags +=" JavaScript big.js"

	#update it
	$root.SelectSingleNode("nuspec:metadata/nuspec:version",$ns).innerText = $packageInfo.version
	$root.SelectSingleNode("nuspec:metadata/nuspec:description",$ns).innerText = $packageInfo.description
	$root.SelectSingleNode("nuspec:metadata/nuspec:tags",$ns).innerText = $tags
	
	$xml.Save("big.js.nuspec")
}


check-bower;
fetch-latest-with-bower;
$packageInfo = get-package-info;
report-library-version $packageInfo;
create-scripts-folder-and-copy-scripts-there;
update-nuspec $packageInfo
compile-nuget-package;
"If the package was compiled successfully, you can publish it via NuGet Push ThePackageName.nukpg";
