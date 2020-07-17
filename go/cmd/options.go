package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/plugins/path_provider"
//	file_picker "github.com/miguelpruivo/flutter_file_picker/go"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(600, 600),
	flutter.WindowDimensionLimits(600, 600, 600, 600),
//	flutter.ForcePixelRatio(1.0),
	flutter.WindowInitialLocation(300, 300),
//	flutter.AddPlugin(&file_picker.FilePickerPlugin{}),

    flutter.AddPlugin(&path_provider.PathProviderPlugin{
    	VendorName:      "flutter.colatea.com",
    	ApplicationName: "zhihuVideo",
    }),
}
