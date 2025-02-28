{include file="sections/header.tpl"}

{if $menu == 'config'}

    <form class="form" method="post" role="form" action="{Text::url('plugin/go_zte_c320_config')}">
        <div class="row">
            <div class="col-md-6 col-md-offset-3">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title">
                            Configuration
                        </h3>
                    </div>
                    <div class="box-body with-border">
                        <div class="form-group">
                            <label>Server URL</label>
                            <textarea type="text" class="form-control" name="go_zte_c320_urls"
                                rows="5" required placeholder="http://domain:port/api/v1">{$_c['go_zte_c320_urls']}</textarea>
                            <span>Multiple server multiple lines</span>
                        </div>
                    </div>
                    <div class="box-footer">
                        <div class="row">
                            <div class="col-xs-4">
                                <a class="btn btn-default btn-sm btn-block" href="{$_url}plugin/go_zte_c320">back</a>
                            </div>
                            <div class="col-xs-8">
                                <button class="btn btn-primary btn-sm btn-block" type="submit">Save</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
{else}
    <style>
        .status-online { color: green; }
        .status-offline { color: red; }
        .rx-good { color: green; }
        .rx-bad { color: red; }
    </style>
    <ul class="nav nav-tabs nav-justified">
        {for $n=0 to $serverscount-1}
            <li role="presentation" {if $server==$n} class="active" {/if}><a
                href="{Text::url('plugin/go_zte_c320&server=', $n)}">{$servers[$n]}</a></li>
        {/for}
        <li role="presentation"><a
        href="{Text::url('plugin/go_zte_c320_config')}"><i class="glyphicon glyphicon-plus"></i> {Lang::T('Add New Server')}</a></li>
    </ul>
    <div class="box">
        <div class="box-body">
            <div class="row mb-3">
                <div class="col-md-6">
                    <label for="boardSelect">Select Board:</label>
                    <select id="boardSelect" class="form-control">
                        <option value="">-- Select Board --</option>
                        <option value="1">Board 1</option>
                        <option value="2">Board 2</option>
                    </select>
                </div>
                <div class="col-md-6">
                    <label for="ponSelect">Select PON:</label>
                    <select id="ponSelect" class="form-control">
                        <option value="">-- Select PON --</option>
                        <option value="1">PON 1</option>
                        <option value="2">PON 2</option>
                        <option value="3">PON 3</option>
                        <option value="4">PON 4</option>
                        <option value="5">PON 5</option>
                        <option value="6">PON 6</option>
                        <option value="7">PON 7</option>
                        <option value="8">PON 8</option>
                        <option value="9">PON 9</option>
                        <option value="10">PON 10</option>
                        <option value="11">PON 11</option>
                        <option value="12">PON 12</option>
                        <option value="13">PON 13</option>
                        <option value="14">PON 14</option>
                        <option value="15">PON 15</option>
                        <option value="16">PON 16</option>
                    </select>
                </div>
            </div>
            <input type="text" id="searchInput" class="form-control mb-3" placeholder="Search...">
            <table id="resultTable" class="table table-bordered">
                <thead>
                    <tr>
                        <th>Board</th>
                        <th>PON</th>
                        <th>ONU ID</th>
                        <th>Name</th>
                        <th>ONU Type</th>
                        <th>Serial Number</th>
                        <th>RX Power (dBm)</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>

    <!-- Modal for ONU Details -->
    <div class="modal fade" id="onuDetailModal" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">ONU Details</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body" id="onuDetailBody"></div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            function fetchData(board, pon) {
                if (!board || !pon) return;
                var apiUrl = '{Text::url('plugin/go_zte_c320_api/server/', $server)}/board/'+board+'/pon/'+pon;
                $.get(apiUrl, function(data) {
                    if (data.code === 200) {
                        var rows = "";
                        {literal}
                        $.each(data.data, function(index, onu) {
                            rows += `<tr>
<td>${onu.board}</td>
<td>${onu.pon}</td>
<td>${onu.onu_id}</td>
<td><a href="#" class="name-link" data-board="${onu.board}" data-pon="${onu.pon}" data-onu="${onu.onu_id}">${onu.name}</a></td>
<td>${onu.onu_type}</td>
<td><a href="#" class="serial-link" data-board="${onu.board}" data-pon="${onu.pon}" data-onu="${onu.onu_id}">${onu.serial_number}</a></td>
<td class="${onu.rx_power <= -24 ? 'rx-good' : 'rx-bad'}">${onu.rx_power}</td>
<td class="${onu.status === 'Online' ? 'status-online' : 'status-offline'}">${onu.status}</td>
                    </tr>`;
                        });
                        {/literal}
                        $("#resultTable tbody").html(rows);
                    }
                });
            }

            $('#boardSelect, #ponSelect').change(function() {
                var board = $('#boardSelect').val();
                var pon = $('#ponSelect').val();
                fetchData(board, pon);
            });

            $('#searchInput').on('keyup', function() {
                var value = $(this).val().toLowerCase();
                $('#resultTable tbody tr').filter(function() {
                    $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
                });
            });

            $(document).on('click', '.name-link, .serial-link', function() {
                var board = $(this).data('board');
                var pon = $(this).data('pon');
                var onuId = $(this).data('onu');
                var detailUrl = '{Text::url('plugin/go_zte_c320_api/server/', $server)}/board/'+board+'/pon/'+pon+'/onu/'+onuId;
                {literal}
                $.get(detailUrl, function(data) {
                    if (data.code === 200) {
                        var onu = data.data;
                        var details = `
<p><strong>Name:</strong> ${onu.name}</p>
<p><strong>Description:</strong> ${onu.description}</p>
<p><strong>ONU Type:</strong> ${onu.onu_type}</p>
<p><strong>Serial Number:</strong> ${onu.serial_number}</p>
<p><strong>RX Power:</strong> ${onu.rx_power}</p>
<p><strong>TX Power:</strong> ${onu.tx_power}</p>
<p><strong>Status:</strong> ${onu.status}</p>
<p><strong>IP Address:</strong> ${onu.ip_address}</p>
                `;
                        $('#onuDetailBody').html(details);
                        $('#onuDetailModal').modal('show');
                    }
                });
            {/literal}
            });
        });
    </script>

{/if}

<div class="bs-callout bs-callout-warning well">
    <p>This Plugin need to install <a href="https://github.com/hotspotbilling/go-snmp-olt-zte-c320"
            target="_blank">go-snmp-olt-zte-c320</a></p>
</div>
{include file="sections/footer.tpl"}