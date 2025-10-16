// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"
import AutocompleteController from "controllers/autocomplete_controller"

console.log('Registering autocomplete controller')
application.register("autocomplete", AutocompleteController)
console.log('Autocomplete controller registered')
