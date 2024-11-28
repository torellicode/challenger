// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import AnnouncementController from "./announcement_controller"
application.register("announcement", AnnouncementController)

import NavController from "./nav_controller"
application.register("nav", NavController)

import DropdownController from "./dropdown_controller"
application.register("dropdown", DropdownController)

import SidebarController from "./sidebar_controller"
application.register("sidebar", SidebarController)

import HamburgerController from "./hamburger_controller"
application.register("hamburger", HamburgerController)
