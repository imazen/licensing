using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Numerics;

namespace ImageResizer.Plugins.LicenseVerifier
{
  /// <summary>
  /// Provides license UTF-8 bytes and signature
  /// </summary>
  public interface ILicenseBlob
  {
      byte[] Signature();
      byte[] Data();
      string Original { get; }
      ILicenseDetails Fields();
  }

  public interface ILicenseDetails
  {
      string Id { get; }
      IReadOnlyDictionary<string, string> Pairs();
      string Get(string key);
      DateTimeOffset? Issued { get; }
      DateTimeOffset? Expires { get; }
      DateTimeOffset? SubscriptionExpirationDate { get; }
  }
}