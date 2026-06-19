from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('contenttypes', '0002_remove_content_type_name'),
    ]

    operations = [
        migrations.CreateModel(
            name='Usuario',
            fields=[
                ('last_login', models.DateTimeField(blank=True, null=True, verbose_name='last login')),
                ('ID_usuario', models.AutoField(db_column='ID_usuario', primary_key=True, serialize=False)),
                ('nombre_usuario', models.CharField(db_column='nombre_usuario', max_length=50, unique=True)),
                ('nombre_pila', models.CharField(db_column='nombre_pila', max_length=40)),
                ('primer_apell', models.CharField(db_column='primer_apell', max_length=40)),
                ('seg_apell', models.CharField(blank=True, db_column='seg_apell', max_length=40, null=True)),
                ('fecha_alta', models.DateField(db_column='fecha_alta')),
                ('correo', models.EmailField(db_column='correo', max_length=80, unique=True)),
                ('contrasena', models.CharField(db_column='contrasena', max_length=100)),
                ('bitacora', models.IntegerField(blank=True, db_column='bitacora', null=True)),
            ],
            options={
                'db_table': 'usuario',
                'managed': False,
            },
        ),
    ]
