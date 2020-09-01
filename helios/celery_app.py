import os

from django.apps import apps
from django.conf import settings

from celery import Celery
from celery.utils.log import get_task_logger

logger = get_task_logger(__name__)

# set the default Django settings module for the 'celery' program.
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")

app = Celery("helios")

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
app.config_from_object("django.conf:settings")

# Load task modules from all registered Django app configs.
app.autodiscover_tasks(lambda: [n.name for n in apps.get_app_configs()])
