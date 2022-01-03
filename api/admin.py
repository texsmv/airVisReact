from django.contrib import admin
from .models import Dataset, Station, Pollutant, AnnualWindow

admin.site.register(Dataset)
admin.site.register(Station)
admin.site.register(Pollutant)
admin.site.register(AnnualWindow)
admin.site.register(DailyWindow)

# Register your models here.
