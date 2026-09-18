from django.contrib import admin

from .models import UserProfile


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "customer")
    list_select_related = ("user", "customer")
    search_fields = ("user__username", "customer__name")
    autocomplete_fields = ("customer",)
