import qs from "qs";
import { since, fromToday } from "../utils/date";

function mixUrl(id, type) {
  if (type === "entries") {
    return `/mixes/${encodeURIComponent(id)}`;
  }
  return `/mixes/${encodeURIComponent(id)}/${type}`;
}

function providers(value) {
  switch (value) {
    case 'youtube':
      return ['YouTube'];
    case 'others':
      return ['SoundCloud', 'Spotify', 'AppleMusic'];
  }
}

function mixParams(type, period, provider) {
  const { newerThan, olderThan } = fromToday(type);
  return {
    type,
    newerThan,
    olderThan,
    period,
    provider
  };
}

var streamId   = document.getElementById("stream_id");
var streamType = document.getElementById("stream_type");
var mixType    = document.getElementById("mix_type");
var period     = document.getElementById("period");
var provider   = document.getElementById("provider");
var mixForm    = document.getElementById("mix_form");

mixForm.addEventListener('submit', function(e) {
  e.preventDefault();
  var url   = mixUrl(streamId.value, streamType.value);
  var params = mixParams(mixType.value,
                         period.value,
                         providers(provider.value));
  var query = qs.stringify(params, { arrayFormat: 'brackets' });
  document.location.href = `${url}?${query}`;
});
