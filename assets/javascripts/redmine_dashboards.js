/*!
# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2022 Liane Hampe <liaham@xmera.de>, xmera.
#
# This plugin program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

/* 
# Reloads the page on the current position in order to
# render changes due to changing css classes when
# the block order changes.
*/ 
function reloadOnCurrentPosition() {
  document.addEventListener("DOMContentLoaded", function (event) {
    var scrollpos = localStorage.getItem('scrollpos');
    if (scrollpos) window.scrollTo(0, scrollpos);
  });
  localStorage.setItem('scrollpos', window.scrollY);
  location.reload();
}

/* 
# Prevents a block, which supports to be centered, from jumping
# to the left of the screen when starting to drag. 
# @params block_selector The css id of the block item.
*/
function adjustCurserAtCenteredBlockItems(block_selector) {
  selector = block_selector + '.center .sort-handle';
  $(selector).mousedown(function (event) {
    block = $(this).parent().parent();
    receiver = block.parent();
    offsetLeftReceiver = receiver.offset().left;
    paddingLeftReceiver = parseInt(receiver.css('padding-left'));
    offsetLeftBlock = block.offset().left;
    marginLeftBlock = offsetLeftBlock - offsetLeftReceiver - paddingLeftReceiver;
    receiver.sortable("option", "cursorAt", { left: - marginLeftBlock + 48 });
  });
}