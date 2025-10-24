// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"
import AutocompleteController from "controllers/autocomplete_controller"

application.register("autocomplete", AutocompleteController)
