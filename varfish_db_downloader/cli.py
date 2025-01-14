"""CLI entry point for VarFish DB Downloader."""

import sys

import click
import jinja2
import requests
import requests_ftp
from loguru import logger

from varfish_db_downloader import wget


@click.group()
def main():
    """Main entry point for the CLI interface"""
    logger.remove()
    fmt = (
        "<green>{time:YYYY-MM-DD HH:mm:ss}</green> | "
        "<level>{level: <7}</level> | "
        "<level>{message}</level>"
    )
    logger.add(sys.stderr, format=fmt)


@main.command(name="tpl")
@click.option("--template", help="Template file")
@click.option("--value", multiple=True, help="Values as --value key=value")
def tpl(template, value):
    """Template a file."""
    with open(template, "rt") as inputf:
        tpl_str = inputf.read()
    vals = {k: v for k, v in (x.split("=", 1) for x in value)}
    j2_template = jinja2.Template(tpl_str)
    print(j2_template.render(vals))


@main.group(name="wget")
def wget_():
    """Group for 'wget' sub commands."""


@wget_.command()
@click.option("--urls-yaml", default="download_urls.yml")
@click.option("--data-dir", default="excerpt-data")
@click.option("--check-certificate/--no-check-certificate", default=True)
@click.option("--output-document", "-O", default=None)
@click.argument("url")
def run_stub_wget(url, check_certificate, data_dir, urls_yaml, output_document):
    """Run the stub ``wget``."""
    _ = check_certificate
    for entry in wget.load_urls_yaml(urls_yaml):
        if entry.url == url:
            wget.copy_excerpt(entry, data_dir, output_document)
            break
    else:
        raise click.ClickException(f"URL {url} not found in {urls_yaml}")


@wget_.command()
@click.option("--urls-yaml", default="download_urls.yml")
@click.option("--data-dir", default="excerpt-data")
@click.option("--check-certificate", default="true")
@click.option("--file-allocation", default="trunc")
@click.option("--out", required=True)
@click.option("--split", default="8")
@click.option("--max-concurrent-downloads", default="8")
@click.option("--max-connection-per-server", default="8")
@click.argument("url")
def run_stub_aria2c(
    url,
    check_certificate,
    file_allocation,
    out,
    split,
    max_concurrent_downloads,
    max_connection_per_server,
    urls_yaml,
    data_dir,
):
    """Run the stub ``aria2c``."""
    _ = check_certificate
    _ = file_allocation
    _ = out
    _ = split
    _ = max_concurrent_downloads
    _ = max_connection_per_server
    for entry in wget.load_urls_yaml(urls_yaml):
        if entry.url == url:
            wget.copy_excerpt(entry, data_dir, out)
            break
    else:
        raise click.ClickException(f"URL {url} not found in {urls_yaml}")


@wget_.command()
@click.option("--urls-yaml", default="download_urls.yml")
def urls_list(urls_yaml):
    """List the URLs known to the wget stub."""
    for url in wget.load_urls_yaml(urls_yaml):
        click.echo(url)


@wget_.command()
@click.option("--urls-yaml", default="download_urls.yml")
@click.option("--data-dir", default="excerpt-data")
@click.option("--force/--no-force", default=False)
@click.argument("urls", nargs=-1)
def urls_download(urls, data_dir, urls_yaml, force):
    """Download excerpts for the given URLs.

    Leave empty to download for all URLs."""
    logger.info("Downloading excerpts to {}...", data_dir)

    seen = set()
    # Process all URLs.
    for url in wget.load_urls_yaml(urls_yaml):
        if not urls or url.url in urls:
            seen.add(url.url)
            wget.download_excerpt(url, data_dir, force)
        else:
            logger.info("  Skipping {}...", url.url)

    logger.info("... done downloading URLs")

    # Check whether all URLs are known if any were given.
    if urls:
        ok = True
        urls = set(urls)
        if seen - urls:
            logger.warning("Some URLs from args not found in YAML: {}", seen - urls)
            ok = False
        if urls - seen:
            logger.warning("Some URLs from YAML not found in args: {}", urls - seen)
            ok = False
        if not ok:
            raise click.ClickException("URL discrepancy (see logs above)")


@wget_.command()
@click.option("--urls-yaml", default="download_urls.yml")
@click.argument("urls", nargs=-1)
def urls_check_upstream(urls, urls_yaml):
    """Check whether the URLs refer to downloadable files.

    Leave ``urls`` empty to check for all URLs."""

    requests_ftp.monkeypatch_session()

    error_count = 0
    for entry in wget.load_urls_yaml(urls_yaml):
        s = requests.Session()
        if not entry.skip_upstream_check and (not urls or entry.url in urls):
            logger.info(" checking {}...", entry.url)
            with s.get(entry.url, allow_redirects=True, stream=True) as r:
                if r.ok:
                    logger.info("   => OK")
                    r.close()
                else:
                    error_count += 1
                    logger.warning("  NOT OK: {}", r)
        else:
            logger.info("  Skipping {}...", entry.url)

    if error_count:
        raise click.ClickException("Problem accessing some URLs (see above)")


@wget_.command()
@click.option("--urls-yaml", default="download_urls.yml")
@click.argument("urls", nargs=-1)
def check_downloaded(urls, urls_yaml):
    """Checks whether the downloaded files are as expected."""


if __name__ == "__main__":
    main()
