# Generated by Django 3.2.9 on 2021-12-06 21:29

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0004_auto_20211206_1842'),
    ]

    operations = [
        migrations.AddField(
            model_name='annualwindow',
            name='o_x',
            field=models.FloatField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='annualwindow',
            name='o_y',
            field=models.FloatField(blank=True, null=True),
        ),
    ]