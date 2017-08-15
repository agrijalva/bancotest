"use strict";
var app = angular.module("yapp", ["ui.router", "ngAnimate", "ngSanitize","ui.carousel"]).config(["$stateProvider", "$urlRouterProvider", function(r, t) {
    t.when("/admin", "/admin/overview"), t.otherwise("/login"), r.state("base", {
        "abstract": !0,
        url: "",
        templateUrl: "pages/base.html"
    })
    .state("login", {
        url: "/login",
        parent: "base",
        cache:false,
        templateUrl: "pages/login/login.html",
        controller: "LoginCtrl"
    })
    .state("admin", {
        url: "/admin",
        parent: "base",
        cache:false,
        templateUrl: "pages/admin.html",
        controller: "DashboardCtrl"
    })
    .state("clientes", {
        url: "/clientes",
        parent: "admin",
        cache:false,
        templateUrl: "pages/clientes/templates/clientes.html",
        controller: "ClientesCtrl"
    })
    .state("nuevo_cliente", {
        url: "/nuevo_cliente",
        parent: "admin",
        cache:false,
        templateUrl: "pages/clientes/templates/nuevo_cliente.html",
        controller: "ClientesCtrl"
    })
    .state("cliente_detalle", {
        url: "/cliente_detalle",
        parent: "admin",
        cache:false,
        templateUrl: "pages/clientes/templates/cliente_detalle.html",
        controller: "ClientesCtrl"
    })
}]);

var API_Path = "http://localhost/bancotest/restapi/v1/index.php"
// var API_Path = "http://pfiscal.nutricionintegral.com.mx/asesoria/restapi/v1/index.php"
var Authorization = 'eb60959f5eac3e1d081244c33d4fb850';

angular.module("yapp").controller("DashboardCtrl", ["$scope", "$state", function(r, t) {
    r.$state = t
}]);