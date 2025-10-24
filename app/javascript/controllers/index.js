// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"
import AutocompleteController from "controllers/autocomplete_controller"
import ValidationController from "controllers/validation_controller"

application.register("autocomplete", AutocompleteController)
application.register("validation", ValidationController)
