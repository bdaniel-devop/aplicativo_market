import os

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    """Cria o superutilizador se não existir, ou actualiza a password se já
    existir — ao contrário de `createsuperuser`, que nunca toca num
    utilizador já existente. Corre em cada deploy (ver render.yaml), lendo
    as credenciais das variáveis de ambiente DJANGO_SUPERUSER_*.
    """

    help = "Garante que o superutilizador existe com a password actual das variáveis de ambiente."

    def handle(self, *args, **options):
        username = os.getenv('DJANGO_SUPERUSER_USERNAME')
        email = os.getenv('DJANGO_SUPERUSER_EMAIL', '')
        password = os.getenv('DJANGO_SUPERUSER_PASSWORD')

        if not username or not password:
            self.stdout.write('DJANGO_SUPERUSER_USERNAME/PASSWORD não definidos — a saltar.')
            return

        user, created = User.objects.get_or_create(username=username, defaults={'email': email})
        user.email = email or user.email
        user.is_staff = True
        user.is_superuser = True
        user.set_password(password)
        user.save()

        action = 'criado' if created else 'actualizado'
        self.stdout.write(self.style.SUCCESS(f'Superutilizador "{username}" {action}.'))
