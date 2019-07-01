from django.urls import path, include
# from django.contrib import admin
# from rest_framework import routers

from userauth import views

urlpatterns = [
    path('login/', views.auth_login),
    path('logout/', views.auth_logout),
    path('signup/', views.signup),
]
