#!/bin/bash

# Run JsonifyWacc using scala-cli with all necessary dependencies
cd /Users/xida/Documents/mainquest/WACC_47

# Create output directory if it doesn't exist
mkdir -p src/main/wacc/xi-extension/wacc-json

# Run the main program
scala-cli run . --main-class wacc.JsonifyWacc -- --batch wacc-examples src/main/wacc/xi-extension/wacc-json 