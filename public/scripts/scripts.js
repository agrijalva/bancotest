"use strict";
var app = angular.module("yapp", ["ui.router", "ngAnimate", "ngSanitize","ui.carousel"]).config(["$stateProvider", "$urlRouterProvider", function(r, t) {
    t.when("/admin", "/admin/overview"), t.otherwise("/ejecutivo"), r.state("base", {
        "abstract": !0,
        url: "",
        templateUrl: "pages/base.html"
    })
    .state("ejecutivo", {
        url: "/ejecutivo",
        parent: "base",
        cache:false,
        templateUrl: "pages/login/ejecutivo.html",
        controller: "LoginCtrl"
    })
    .state("cajero", {
        url: "/cajero",
        parent: "base",
        cache:false,
        templateUrl: "pages/login/cajero.html",
        controller: "LoginCtrl"
    })
    .state("cliente", {
        url: "/cliente",
        parent: "base",
        cache:false,
        templateUrl: "pages/login/cliente.html",
        controller: "LoginCtrl"
    })
    .state("admin", {
        url: "/admin",
        parent: "base",
        cache:false,
        templateUrl: "pages/admin.html",
        controller: "AdminCtrl"
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
    .state("depositos", {
        url: "/depositos",
        parent: "admin",
        cache:false,
        templateUrl: "pages/depositos/depositos.html",
        controller: "DepositoCtrl"
    })
    .state("panel", {
        url: "/panel",
        parent: "admin",
        cache:false,
        templateUrl: "pages/cliente/cliente.html",
        controller: "ClienteCtrl"
    })
}]);

var API_Path = "http://localhost/bancotest/restapi/v1/index.php"
// var API_Path = "http://pfiscal.nutricionintegral.com.mx/asesoria/restapi/v1/index.php"

angular.module("yapp").controller("DashboardCtrl", ["$scope", "$state", function(r, t) {
    r.$state = t
}]);