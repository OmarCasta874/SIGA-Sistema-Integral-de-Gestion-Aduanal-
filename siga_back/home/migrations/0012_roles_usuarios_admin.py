from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0011_pago_incidencia'),
    ]

    operations = [
        migrations.RunSQL(
            sql="UPDATE usuario SET rol='Administrador' WHERE nombre_usuario IN ('admin01','admin02','super01','audit01')",
            reverse_sql="UPDATE usuario SET rol='Agente Aduanal' WHERE nombre_usuario IN ('admin01','admin02','super01','audit01')",
        ),
    ]
