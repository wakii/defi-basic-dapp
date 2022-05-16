import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header() {
  return (
    <a href="https://wakii-dex-v1.surge.sh/" target="_blank" rel="noopener noreferrer">
      <PageHeader
        title="😎 wakii-dapp"
        subTitle="Basic Single Pool Dex App for learing by doing, front-end w/ scaffold-eth"
        style={{ cursor: "pointer" }}
      />
    </a>
  );
}
