'use strict';

var React = require('react');
var {
  PropTypes,
} = React;
var ReactNative = require('react-native');
var {
  EdgeInsetsPropType,
  NativeMethodsMixin,
  Platform,
  ReactNativeViewAttributes,
  View,
  Animated,
  requireNativeComponent,
  NativeModules,
} = ReactNative;

var MapMarker = require('./MapMarker');
var MapPolyline = require('./MapPolyline');
var MapPolygon = require('./MapPolygon');
var MapCircle = require('./MapCircle');
var MapCallout = require('./MapCallout');

var MapView = React.createClass({
  mixins: [NativeMethodsMixin],

  viewConfig: {
    uiViewClassName: 'AMap',
    validAttributes: {
      region: true,
    },
  },

  propTypes: {
      ...View.propTypes,

      style: View.propTypes.style,

      /**
       * [apiKey amap's apiKey]
       * @type {[type]}
       */
      apiKey: PropTypes.string,
      /**
       * If `true` the app will ask for the user's location and focus on it.
       * Default value is `false`.
       *
       * **NOTE**: You need to add NSLocationWhenInUseUsageDescription key in
       * Info.plist to enable geolocation, otherwise it is going
       * to *fail silently*!
       */
      showsUserLocation: PropTypes.bool,

      /**
       * If `false` points of interest won't be displayed on the map.
       * Default value is `true`.
       *
       */
      showsPointsOfInterest: PropTypes.bool,

      /**
       * If `false` compass won't be displayed on the map.
       * Default value is `true`.
       *
       * @platform ios
       */
      showsCompass: PropTypes.bool,

      /**
       * If `false` the user won't be able to pinch/zoom the map.
       * Default value is `true`.
       *
       */
      zoomEnabled: PropTypes.bool,

      zoomLevel: PropTypes.number,
      /**
       * If `false` the user won't be able to pinch/rotate the map.
       * Default value is `true`.
       *
       */
      rotateEnabled: PropTypes.bool,

      /**
       * If `false` the user won't be able to change the map region being displayed.
       * Default value is `true`.
       *
       */
      scrollEnabled: PropTypes.bool,

      /**
       * If `false` the user won't be able to adjust the camera’s pitch angle.
       * Default value is `true`.
       *
       */
      pitchEnabled: PropTypes.bool,

      /**
       * A Boolean indicating whether the map shows scale information.
       * Default value is `false`
       *
       */
      showsScale: PropTypes.bool,

      /**
       * A Boolean indicating whether the map displays extruded building information.
       * Default value is `true`.
       */
      showsBuildings: PropTypes.bool,

      /**
       * A Boolean value indicating whether the map displays traffic information.
       * Default value is `false`.
       */
      showsTraffic: PropTypes.bool,

      /**
       * A Boolean indicating whether indoor maps should be enabled.
       * Default value is `false`
       *
       * @platform android
       */
      showsIndoors: PropTypes.bool,

      /**
       * The map type to be displayed.
       *
       * - standard: standard road map (default)
       * - satellite: satellite view
       */
      mapType: PropTypes.oneOf([
          'standard',
          'satellite',
      ]),

      userTrackingMode: PropTypes.oneOf([
          'none',
          'follow',
          'followWithHeading',
      ]),

      /**
       * The region to be displayed by the map.
       *
       * The region is defined by the center coordinates and the span of
       * coordinates to display.
       */
      region: PropTypes.shape({
          /**
           * Coordinates for the center of the map.
           */
          latitude: PropTypes.number.isRequired,
          longitude: PropTypes.number.isRequired,

          /**
           * Difference between the minimun and the maximum latitude/longitude
           * to be displayed.
           */
          latitudeDelta: PropTypes.number,
          longitudeDelta: PropTypes.number,
      }),

      /**
       * The initial region to be displayed by the map.  Use this prop instead of `region`
       * only if you don't want to control the viewport of the map besides the initial region.
       *
       * Changing this prop after the component has mounted will not result in a region change.
       *
       * This is similar to the `initialValue` prop of a text input.
       */
      initialRegion: PropTypes.shape({
          /**
           * Coordinates for the center of the map.
           */
          latitude: PropTypes.number.isRequired,
          longitude: PropTypes.number.isRequired,

          /**
           * Difference between the minimun and the maximum latitude/longitude
           * to be displayed.
           */
          latitudeDelta: PropTypes.number,
          longitudeDelta: PropTypes.number,
      }),

      /**
       * Maximum size of area that can be displayed.
       *
       * @platform ios
       */
      maxDelta: PropTypes.number,

      /**
       * Minimum size of area that can be displayed.
       *
       * @platform ios
       */
      minDelta: PropTypes.number,

      /**
       * Insets for the map's legal label, originally at bottom left of the map.
       * See `EdgeInsetsPropType.js` for more information.
       */
      legalLabelInsets: EdgeInsetsPropType,

      /**
       * Callback that is called continuously when the user is dragging the map.
       */
      onRegionChange: PropTypes.func,

      /**
       * Callback that is called once, when the user is done moving the map.
       */
      onRegionChangeComplete: PropTypes.func,

      /**
       * Callback that is called when user taps on the map.
       */
      onPress: PropTypes.func,

      /**
       * Callback that is called when user makes a "long press" somewhere on the map.
       */
      onLongPress: PropTypes.func,

      /**
       * Callback that is called when a marker on the map is tapped by the user.
       */
      onMarkerPress: PropTypes.func,

      /**
       * Callback that is called when a marker on the map becomes selected. This will be called when
       * the callout for that marker is about to be shown.
       *
       * @platform ios
       */
      onMarkerSelect: PropTypes.func,

      /**
       * Callback that is called when a marker on the map becomes deselected. This will be called when
       * the callout for that marker is about to be hidden.
       *
       * @platform ios
       */
      onMarkerDeselect: PropTypes.func,

      /**
       * Callback that is called when a callout is tapped by the user.
       */
      onCalloutPress: PropTypes.func,

      /**
       * Callback that is called when the user initiates a drag on a marker (if it is draggable)
       */
      onMarkerDragStart: PropTypes.func,

      /**
       * Callback called continuously as a marker is dragged
       */
      onMarkerDrag: PropTypes.func,

      /**
       * Callback that is called when a drag on a marker finishes. This is usually the point you
       * will want to setState on the marker's coordinate again
       */
      onMarkerDragEnd: PropTypes.func,
  },

  getInitialState() {
      return {
          isReady: false
      }
  },

  getDefaultProps: function() {
      return {
          zoomLevel: 13
      };
  },


  componentDidMount() {
      const {
          region,
          initialRegion,
          showsScale
      } = this.props;
      if (region && this.state.isReady) {
          this.refs.map.setNativeProps({
              region
          });
      } else if (initialRegion && this.state.isReady) {
          this.refs.map.setNativeProps({
              region: initialRegion
          });
      }
  },

  componentWillUpdate(nextProps) {
      var a = this.__lastRegion;
      var b = nextProps.region;
      if (!a || !b) return;
      if (
          a.latitude !== b.latitude ||
          a.longitude !== b.longitude ||
          a.latitudeDelta !== b.latitudeDelta ||
          a.longitudeDelta !== b.longitudeDelta
      ) {
          this.refs.map.setNativeProps({
              region: b
          });
      }
  },

  _onMapReady() {
      const {
          region,
          initialRegion
      } = this.props;
      if (typeof this.props.onMapReady == 'function') {
          this.props.onMapReady()
      }
      if (region) {
          this.refs.map.setNativeProps({
              region
          });
      } else if (initialRegion) {
          this.refs.map.setNativeProps({
              region: initialRegion
          });
      }
      this.setState({
          isReady: true
      });
  },

  _onLayout(e) {
      const {
          region,
          initialRegion,
          onLayout
      } = this.props;
      const {
          isReady
      } = this.state;
      if (region && isReady && !this.__layoutCalled) {
          this.__layoutCalled = true;
          this.refs.map.setNativeProps({
              region
          });
      } else if (initialRegion && isReady && !this.__layoutCalled) {
          this.__layoutCalled = true;
          this.refs.map.setNativeProps({
              region: initialRegion
          });
      }
      onLayout && onLayout(e);
  },

  _onChange(event: Event) {
      this.__lastRegion = event.nativeEvent.region;
      if (event.nativeEvent.continuous) {
          this.props.onRegionChange &&
              this.props.onRegionChange(event.nativeEvent.region);
      } else {
          this.props.onRegionChangeComplete &&
              this.props.onRegionChangeComplete(event.nativeEvent.region);
      }
  },

  animateToRegion(region, duration) {
      this._runCommand('animateToRegion', [region, duration || 500]);
  },

  animateToCoordinate(latLng, duration) {
      this._runCommand('animateToCoordinate', [latLng, duration || 500]);
  },

  fitToElements(animated) {
      this._runCommand('fitToElements', [animated]);
  },

  animateToZoomLevel(zoomLevel) {
      this._runCommand('animateToZoomLevel', [zoomLevel])
  },

  _getHandle() {
      return ReactNative.findNodeHandle(this.refs.map);
  },

  _runCommand(name, args) {
      switch (Platform.OS) {
          case 'android':
              NativeModules.UIManager.dispatchViewManagerCommand(
                  this._getHandle(),
                  NativeModules.UIManager.AMap.Commands[name],
                  args
              );
              break;

          case 'ios':
              NativeModules.AMapManager[name].apply(
                  NativeModules.AMapManager[name], [this._getHandle(), ...args]
              );
              break;
      }
  },


  render() {
      let props = {
          ...this.props,
          region: null,
          initialRegion: null,
          onChange: this._onChange,
          onMapReady: this._onMapReady,
          onLayout: this._onLayout,
      };
      if (Platform.OS === 'ios' && props.mapType === 'terrain') {
          props.mapType = 'standard';
      }
      if (!props.style || !props.style.flex) {
          props.style = props.style || {}
          props.style.flex = 1
      }

      return ( < AMap ref = "map" {...props}/>);
  }
})

var AMap = requireNativeComponent('AMap', MapView, {
  nativeOnly: {
    onChange: true,
    onMapReady: true,
  },
});

MapView.Marker = MapMarker;
MapView.Polyline = MapPolyline;
MapView.Polygon = MapPolygon;
MapView.Circle = MapCircle;
MapView.Callout = MapCallout;

MapView.Animated = Animated.createAnimatedComponent(MapView);

module.exports = MapView;
