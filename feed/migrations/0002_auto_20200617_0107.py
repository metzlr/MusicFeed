# Generated by Django 3.0.3 on 2020-06-17 01:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feed', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='artistgroup',
            name='name',
            field=models.CharField(max_length=25),
        ),
    ]