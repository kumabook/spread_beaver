import qs from "qs";
import { daily, weekly, monthly } from "../utils/newerThan";

function mixUrl(id, type) {
  if (type === "entries") {
    return `/mixes/${encodeURIComponent(id)}`;
  }
  return `/mixes/${encodeURIComponent(id)}/${type}`;
}

function newerThan(peroid) {
  switch (peroid) {
    case "daily":
      return daily();
    case "weekly":
      return weekly();
    case "monthly":
      return monthly();
    default:
      return null;
  }
}

function mixParams(type, period) {
  return {
    type,
    newerThan: newerThan(period),
    period
  };
}

var streamId   = document.getElementById("stream_id");
var streamType = document.getElementById("stream_type");
var mixType    = document.getElementById("mix_type");
var period     = document.getElementById("period");
var mixForm    = document.getElementById("mix_form");

mixForm.addEventListener('submit', function(e) {
  e.preventDefault();
  var url   = mixUrl(streamId.value, streamType.value);
  var query = qs.stringify(mixParams(mixType.value, period.value));
  document.location.href = `${url}?${query}`;
});
