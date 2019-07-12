from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from userauth.models import User, BookUser, MovieUser

admin.site.register(User, UserAdmin)
admin.site.register(BookUser)
admin.site.register(MovieUser)
