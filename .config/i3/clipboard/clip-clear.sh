#!/usr/bin/env bash
# Polybar right-click: wipe copyq clipboard history, then refresh the polybar
# label so it immediately reads "Empty". Removing items does NOT trigger copyq's
# "Polybar refresh" automatic command (that only fires on *new* clipboard
# content), so without the explicit refresh the label would keep showing the
# last item and you couldn't tell the history was actually cleared.
copyq --start-server eval 'true' >/dev/null 2>&1   # self-heal if server is down
copyq eval -- 'var a=[];for(var i=size();i-->0;)a.push(i);if(a.length)remove.apply(null,a)' >/dev/null 2>&1
polybar-msg action '#clipboard.hook.0' >/dev/null 2>&1
