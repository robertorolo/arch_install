#!/bin/bash

echo "This script will install arch linux."

# keyboard configuration
keyboard_layout=us
echo "Configuring keyboard as: $keyboard_layout"
loadkeys $keyboard_layout
